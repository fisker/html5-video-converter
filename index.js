var ffmpegBIN = require('ffmpeg-static').path
var execa = require('execa')
var inquirer = require('inquirer')
var argv = require('yargs').argv
var fs = require('fs').promises
var path = require('path')
var he = require('he')
var mkdirp = require('mkdirp')

;(async () => {
  var inputFile = path.resolve(argv.file)
  await fs.stat(inputFile)

  var ext = path.extname(inputFile)
  var baseName = path.basename(inputFile, ext)

  var dest = path.resolve(
    argv.dest ||
    argv.dist ||
    path.join(path.dirname(inputFile), baseName)
  )

  var version = await execa.stdout(ffmpegBIN, [
    '-version'
  ])

  console.log(version)

  var questions = [
    {
      type: 'checkbox',
      name: 'options',
      message: 'files:',
      choices: [
        {
          value: 'mp4',
          checked: true
        },
        {
          value: 'webm',
          checked: true
        },
        {
          value: 'ogv',
          checked: true
        },
        {
          value: 'poster',
          checked: true
        },
        {
          value: 'html',
          checked: true
        }
      ]
    }
  ]

  var {options} = await inquirer.prompt(questions)
  var fileNames = {}

  var videoArgs = [
    `-i "${inputFile}"`,
    '-b:v 1500k',
    '-b:a 128k',
    '-s 640x360',
    '-movflags faststart',
  ]

  mkdirp.sync(dest)

  if (options.includes('mp4')) {
    fileNames.mp4 = baseName + '.mp4'
    await execa(ffmpegBIN, [
      ...videoArgs,
      '-vcodec libx264',
      `"${path.join(dest, fileNames.mp4)}"`,
    ], {
      windowsVerbatimArguments: true
    })
  }

  if (options.includes('webm')) {
    fileNames.webm = baseName + '.webm'
    await execa(ffmpegBIN, [
      ...videoArgs,
      '-vcodec libvpx',
      '-acodec libvorbis',
      '-f webm',
      `"${path.join(dest, fileNames.webm)}"`,
    ], {
      windowsVerbatimArguments: true
    })
  }

  if (options.includes('ogv')) {
    fileNames.ogv = baseName + '.ogv'
    await execa(ffmpegBIN, [
      ...videoArgs,
      '-vcodec libtheora',
      '-acodec libvorbis',
      '-f webm',
      `"${path.join(dest, fileNames.ogv)}"`,
    ], {
      windowsVerbatimArguments: true
    })
  }

  if (options.includes('poster')) {
    fileNames.poster = baseName + '.jpg'
    await execa(ffmpegBIN, [
      `-i "${inputFile}"`,
      '-ss 00:10',
      '-vframes 1',
      '-r 1',
      '-s 640x360',
      '-f image2',
      `"${path.join(dest, fileNames.poster)}"`,
    ], {
      windowsVerbatimArguments: true
    })
  }

  if (options.includes('html')) {
    fileNames.html = baseName + '.html'
    var html = `<!DOCTYPE html>
<html>
<head>
 <title>${he.escape(baseName + ext)}</title>
</head>
<body>
<video
  ${
    fileNames.poster
    ? 'poster="' + he.escape(fileNames.poster) + '"'
    : ''
  }
  autoplay
  controls
  preload
  loop
  playsinline
  webkit-playsinline>

  ${
    fileNames.mp4
    ? '<source src="' + he.escape(fileNames.mp4)  + '" type="video/mp4; codecs=&quot;avc1.42E01E, mp4a.40.2&quot;">'
    : ''
  }

  ${
    fileNames.ogv
    ? '<source src="' + he.escape(fileNames.ogv)  + '" type="video/ogg; codecs=&quot;theora, vorbis&quot;">'
    : ''
  }

  ${
    fileNames.webm
    ? '<source src="' + he.escape(fileNames.webm)  + '" type="video/webm; codecs=&quot;vp8.0, vorbis&quot;">'
    : ''
  }
</video>
<p>html5 video/audio converter by fisker Cheung</p>
</body>
</html>
`.split('\n').map(x => x.trim()).filter(Boolean).join('\n')
    await fs.writeFile(path.join(dest, fileNames.html), html)
    execa.shell(`start ${path.join(dest, fileNames.html)}`)
  }
})()
