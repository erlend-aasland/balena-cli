_ = require('lodash')
TypedError = require('typed-error')
log = require('../log/log')

exports.NotFound = class NotFound extends TypedError

	# Construct a Not Found error
	#
	# @param {String} name name of the thing that was not found
	#
	# @example Application not found
	#		throw new resin.errors.NotFound('application')
	#		Error: Couldn't find application
	#
	constructor: (name) ->
		@message = "Couldn't find #{name}"

	# Error code
	code: 1

exports.InvalidConfigFile = class InvalidConfigFile extends TypedError

	# Construct an Invalid Config File error
	#
	# @param {String} file the name of the invalid configuration file
	#
	# @example Invalid config file error
	#		throw new resin.errors.InvalidConfigFile('/opt/resin.conf')
	#		Error: Invalid configuration file: /opt/resin.conf
	#
	constructor: (file) ->
		@message = "Invalid configuration file: #{file}"

	# Error code
	code: 1

exports.InvalidCredentials = class InvalidCredentials extends TypedError

	# Construct an Invalid Credentials error
	#
	# @example Invalid credentials error
	#		throw new resin.errors.InvalidCredentials()
	#		Error: Invalid credentials
	#
	constructor: ->
		@message = 'Invalid credentials'

	# Error code
	code: 1

exports.NotAny = class NotAny extends TypedError

	# Construct an Not Any error
	#
	# @param {String} name name of the thing that the user doesn't have
	#
	# @example Not Any applications error
	#		throw new resin.errors.NotAny('applications')
	#		Error: You don't have any applications
	#
	constructor: (name) ->
		@message = "You don't have any #{name}"

	# Error code
	code: 0

# Handle error instances
#
# Prints the message to stderr and aborts the program with the corresponding error code, or 0 if none.
#
# @param {Error} error the error instance
# @param {Boolean} exit whether to exit or not (defaults to true)
#
# @example Handle error
#		error = new Error('My Error')
#		shouldExit = false
#		resin.errors.handle(error, shouldExit)
#
exports.handle = (error, exit = true) ->
	return if not error? or error not instanceof Error

	if error.message?
		log.error(error.message)

	if _.isNumber(error.code)
		errorCode = error.code
	else
		errorCode = 1

	process.exit(errorCode) if exit