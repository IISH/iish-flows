/**
 place_command.groovy

 Adds a command for all subfolders within in the desired folder

 Usage: place_command -folder [folder] -command [command]
 **/

def arguments = [:]
for (int i = 0; i < args.length; i++) {
    if (args[i][0] == '-') {
        arguments.put(args[i].substring(1), args[i + 1])
    }
}

if (arguments.folder && arguments.command) {
    new File(arguments.folder).listFiles().each {
        if (it.isDirectory()) {
            def file = new File(it, (arguments.command.endsWith(".txt")) ?: arguments.command + ".txt")
            if (!file.exists()) {
                FileOutputStream fileOutputStream = new FileOutputStream(file)
                fileOutputStream.write(new Date().toString().bytes)
                fileOutputStream.close()
            }
        }
    }
}