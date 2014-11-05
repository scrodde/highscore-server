module.exports = (grunt) ->
  # Do grunt-related things in here
  grunt.loadNpmTasks('grunt-shipit')

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')

    shipit:
      options:
        workspace: '.tmp',
        deployTo: '/home/scrodde/apps/highscore-server',
        repositoryUrl: 'https://github.com/scrodde/highscore-server',
        ignores: ['.git', 'node_modules', 'db'],
        keepReleases: 5

      staging:
        servers: 'scrodde@scrod.de'
  })


  grunt.registerTask('setup', ->
    done = @async()

    grunt.shipit.remote("mkdir -p #{grunt.shipit.config.deployTo}/shared/db", (err) ->
      return done(err) if err
      grunt.log.oklns('Shared database folder created.')
      done()
    )
  )

  grunt.registerTask('start', ->
    done = @async()
    currentPath = "#{grunt.shipit.config.deployTo}/current"
    grunt.shipit.remote("cd #{currentPath} && npm start", done)
  )

  grunt.registerTask('stop', ->
    done = @async()
    currentPath = "#{grunt.shipit.config.deployTo}/current"
    grunt.shipit.remote("cd #{currentPath} && npm stop", done)
  )

  grunt.registerTask('symlink', ->
    done = @async()

    currentPath = grunt.shipit.releasePath
    dbPath = "#{grunt.shipit.config.deployTo}/shared/db"

    grunt.shipit.remote("cd #{currentPath} && ln -s #{dbPath} db", (err) ->
      return done(err) if err
      grunt.log.oklns('Symlinked database folder to shared.')
      done()
    )
  )

  grunt.registerTask('migrate', ->
    done = @async()
    currentPath = grunt.shipit.releasePath
    grunt.shipit.remote("cd #{currentPath} && npm install && knex migrate:latest", done)
  )


  grunt.shipit.on('updated', ->
    grunt.task.run(['symlink', 'migrate'])
  )
