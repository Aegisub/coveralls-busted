coverage = require "coveralls.coverage"
require "json"

export ^

class coveralls extends coverage.CodeCoverage
	Travis: "travis-ci"
	Jenkins: "jenkins"
	Semaphore: "semaphore"
	Circle: "circleci"
	Local: "local"
	Debug: "debug"

	new: =>
		@__source_files = {}
		-- The continuous integration service
		@service_name = @@Travis
		-- The continuous integration service job id
		@service_job_id = nil
		-- The secret repo token for your repository, found at the bottom of
		-- your repository's page on Coveralls.
		@repo_token = nil

		@dirname = ''
		@ext = '*.moon'
		@srcs = {}

		super!

	coverDir: (dirname, ext = '*.moon') =>
		dir = require "pl.dir"
		@cover f for f in *(dir.getfiles dirname, ext)
		@coverDir d, ext for d in *(dir.getdirectories dirname)

	cover: (fname) =>
		file_coverage = @file_coverage fname
		return unless file_coverage
		c = file_coverage.coverage

		length = #c
		if length == 0
			i = 1
			for line in io.lines fname
				c[i] = if coveralls.no_coverage(line)
						json.util.null
					else
						0
				i += 1
		else
			for k, v in pairs c
				length = k if k > length

			for i = 1, length
				file_coverage.coverage[i] = json.util.null if c[i] == nil


		table.insert @__source_files, file_coverage if #c > 0

	send: =>
		if #@__source_files == 0
			print "\nNo source files to send to Coveralls"
			return

		if not @service_job_id
			env = nil
			switch @service_name
				when @@Travis
					env = 'TRAVIS_JOB_ID'
				when @@Jenkins
					env = 'BUILD_NUMBER'
				when @@Semaphore
					env = 'SEMAPHORE_BUILD_NUMBER'
				when @@Circle
					env = 'CIRCLE_BUILD_NUM'
				when @@Local
					return
				when @@Debug
					moon = require "moon"
					moon.p @__source_files
					print json.encode
						service_name: @service_name
						service_job_id: @service_job_id
						repo_token: @repo_token
						source_files: @__source_files
					return

			@service_job_id = os.getenv env

		assert @service_job_id, "A service_job_id must be specified"

		tmpnam = os.tmpname!
		file = io.open tmpnam, 'w'
		file\write json.encode
			service_name: @service_name
			service_job_id: @service_job_id
			repo_token: @repo_token
			source_files: @__source_files
		file\close!

		curl = io.popen "curl --form json_file=@#{tmpnam} https://coveralls.io/api/v1/jobs"
		response = curl\read '*all'
		curl\close!

		os.remove tmpnam

		if response\match '^<'
			error "Error updating Coveralls: #{response}"

		msg = json.decode response
		print msg.url

Coveralls = coveralls!
