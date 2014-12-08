fs = require('fs')
path = require('path')
rimraf = require('rimraf')
fsUtils = require('./fs-utils/fs-utils')
exports.prefix = require('./data-prefix')

# TODO: codo doesn't recognises functions in this file
# because they have haltIfNoPrefix before the definition.

# @nodoc
haltIfNoPrefix = (callback) ->
	return ->
		if not exports.prefix.get()?
			throw new Error('Did you forget to set a prefix?')
		return callback.apply(null, arguments)

# @nodoc
constructPath = (key) ->
	prefix = exports.prefix.get()
	result = path.join(prefix, key)

	if not fsUtils.isValidPath(result)
		throw new Error('Invalid path')

	return result

# Get data by key
#
# We call "data" to the information saved by the application in order to work properly.
# Examples of data are the token, cached downloads and much more.
#
# @param {String} key path relative to dataPrefix
# @param {Object} options node fs options for when reading the resource
# @param {Function} callback callback(error, value)
#
# @throw {Error} Will throw if data prefix was not previously set
#
# @example Get token
#		resin.data.get 'token', encoding: 'utf8', (error, token) ->
#			throw error if error?
#			console.log(token)
#
#	@example Get nested token
#		# Note: You should use the appropriate path.sep for your os
#		# http://nodejs.org/api/path.html#path_path_sep
#		resin.data.get 'my/nested/token', encoding: 'utf8', (error, token) ->
#			throw error if error?
#			console.log(token)
#
exports.get = haltIfNoPrefix (key, options, callback) ->
	exports.has key, (hasKey) ->
		if not hasKey

			# Pass undefined explicitly, otherwise
			# async gets confused
			return callback?(null, undefined)

		keyPath = constructPath(key)
		fs.readFile(keyPath, options, callback)

# Set/Update a data resource
#
# @param {String} key path relative to dataPrefix
# @param {String, Buffer} value key value
# @param {Object} options node fs options for when reading the resource
# @param {Function} callback callback(error)
#
# @throw {Error} Will throw if data prefix was not previously set
#
# @note You can save a buffer, but we strongly recommend saving plain text when possible
#
# @example Set value
#		resin.data.set 'customValue', 'Hello World', encoding: 'utf8', (error) ->
#			throw error if error?
#			console.log("Value saved to #{resin.data.prefix.get()}/customValue")
#
exports.set = haltIfNoPrefix (key, value, options, callback) ->
	keyPath = constructPath(key)
	fs.writeFile(keyPath, value, options, callback)

# Check if value exists
#
# @param {String} key path relative to dataPrefix
# @param {Function} callback callback(hasKey)
#
# @throw {Error} Will throw if data prefix was not previously set
#
# @example Has value
#		resin.data.has 'foo/bar', (hasFooBar) ->
#			if hasFooBar
#				console.log('It\'s there!')
#			else
#				console.log('It\'s not there!')
#
exports.has = haltIfNoPrefix (key, callback) ->
	keyPath = constructPath(key)
	fs.exists(keyPath, callback)

# Remove a key
#
# @param {String} key path relative to dataPrefix
# @param {Function} callback callback(error)
#
# @throw {Error} Will throw if data prefix was not previously set
#
# @example Remove token
#		resin.data.remove 'token', (error) ->
#			throw error if error?
#
exports.remove = haltIfNoPrefix (key, callback) ->
	keyPath = constructPath(key)

	fsUtils.isDirectory keyPath, (error, isDirectory) ->
		return callback(error) if error?

		removeFunction = if isDirectory then rimraf else fs.unlink
		removeFunction(keyPath, callback)