## An autoload Node which exists to store persistent references to resources,
## ensuring they remain loaded between scene changes.
##
## The ResourceCache allows storing resource references via [method cache_resource], [method load_and_cache]
## or [method load_and_cache_async]. [br]
## Presence of resources or resource paths in the cache may be queried via [method is_path_cached] or [method is_resource_cached]. [br]
## Resources can be removed from the cache via [method drop_path] or [method drop_resource]. [br]
## [br]
## Because this Node exists as an autoload and stores strong references to any resources in the cache,
## this will persist the resource [url=https://docs.godotengine.org/en/stable/classes/class_refcounted.html]Reference Counts[/url]
## and prevent them from being freed from memory. [br]
## This is especially useful for resources which are used consistently throughout multiple scenes but may
## lose all their reference counts during a scene change.
extends Node

# The internal cache.
# Keeps strong references to any stored resource paths.
var _cache: Dictionary[String, Resource]


## Stores a reference to the given [param resource] in this cache. [br]
## Because this is an autoload node, this means the cached resource
## will persist in memory between scene changes indefinitely,
## until freed from the cache with [method drop_resource]. [br]
## This resource will be saved under its [member Resource.resource_path]
## and will be rejected if this path is empty or invalid.
func cache_resource(resource: Resource) -> bool:
	if resource == null:
		return false
	var path: String = resource.resource_path
	if path.is_empty():
		return false
	_cache[path] = resource
	return true


## Returns whether the given [param resource_path] exists in this cache.
func is_path_cached(resource_path: String) -> bool:
	return _cache.has(resource_path)


## Returns whether the [code]resource_path[/code] of the given
## [param resource] exists in this cache.
func is_resource_cached(resource: Resource) -> bool:
	return resource != null and _cache.has(resource.resource_path)


## Loads the resource at the given [param resource_path] from or into this cache. [br]
## If the resource does not already exist in this cache, it will be added and therefore
## persisted indefinitely in memory until freed from the cache with [method drop_path]. [br]
## Returns the resulting [Resource] if the [param resource_path]
## and [param type_hint] were valid, or [code]null[/code] if not.
func load_and_cache(resource_path: String, type_hint: String = "") -> Resource:
	var resource: Resource = _cache.get(resource_path)
	if resource == null and ResourceLoader.exists(resource_path, type_hint):
		resource = ResourceLoader.load(resource_path, type_hint, ResourceLoader.CACHE_MODE_REUSE)
		_cache[resource_path] = resource
	return resource


## Loads the resource at the given [param resource_path] from or into this cache. [br]
## If the resource does not already exist in this cache, it will be added and therefore
## persisted indefinitely in memory until freed from the cache with [method drop_path]. [br]
## This function is [b]asynchronous[/b] and performs resource loading as a coroutine. [br]
## Returns the resulting [Resource] if the [param resource_path]
## and [param type_hint] were valid, or [code]null[/code] if not. [br]
## If called without [code]await[/code] then this function will still store the resource in the cache upon loading.
func load_and_cache_async(resource_path: String, type_hint: String = "") -> Resource:
	var resource: Resource = _cache.get(resource_path)
	if resource == null and ResourceLoader.exists(resource_path, type_hint):
		resource = await ResourceLoadUtil.load_async(resource_path, type_hint, ResourceLoader.CACHE_MODE_REUSE)
		_cache[resource_path] = resource
	return resource


## Checks whether the given [param resource_path] is in the cache and
## tries to load it if it is not. [br]
## Returns whether the resource was loaded into the cache.
func ensured_path_cached(resource_path: String) -> bool:
	if _cache.has(resource_path):
		return true
	return load_and_cache(resource_path) != null


## Checks whether the given [param resource_path] is in the cache and
## tries to load it if it is not. [br]
## Returns whether the resource was loaded into the cache. [br]
## This function is [b]asynchronous[/b] and performs resource loading as a coroutine. [br]
## If called without [code]await[/code] then this function will still store the resource in the cache upon loading.
func ensured_path_cached_async(resource_path: String) -> bool:
	if _cache.has(resource_path):
		return true
	return await load_and_cache_async(resource_path) != null


## Checks whether the [code]resource_path[/code] of the given
## [param resource] exists in this cache and tries to cache it if it is not. [br]
## Returns whether the resource was loaded into the cache.
func ensure_resource_cached(resource: Resource) -> bool:
	if resource == null or resource.resource_path.is_empty():
		return false
	if _cache.has(resource.resource_path):
		return true
	return cache_resource(resource)


## Drops the resource at the given [param resource_path] from this cache. [br]
## Returns whether the resource existed in the cache.
func drop_path(resource_path: String) -> bool:
	return _cache.erase(resource_path)


## Drops the given [param resource] from this cache via its [code]resource_path[/code]. [br]
## Returns whether the resource existed in the cache.
func drop_resource(resource: Resource) -> bool:
	return drop_path(resource.resource_path)


## Clears all resources out of this cache.
func clear() -> void:
	_cache.clear()
