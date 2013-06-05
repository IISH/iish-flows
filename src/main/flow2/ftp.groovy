/**
 *
 ftp.groovy

 Usage:
 ftp.groovy [foldername]
 * */


def folder = (args.size() == 0) ? new Date().format('yyyy-DD-mm') : args[0]
def root_folder = new File(System.getenv()['ROOT_FLOW2'], folder)
def log_files = new File(System.getenv()['SORIMPORT_HOME'], 'log/flow2/' + folder + '.files.ftp.log')
def log_instruction = new File(System.getenv()['SORIMPORT_HOME'], 'log/flow2/' + folder + '.instruction.ftp.log')
def log_retry = new File(System.getenv()['SORIMPORT_HOME'], 'log/flow2/' + folder + '.retry.ftp.log')
def ftp_script = new File(System.getenv()['SORIMPORT_HOME'], 'log/flow2/' + folder + '.stagingarea.objectrepository.org.ftp.txt')
def instruction = new File(root_folder, 'instruction.xml')

if (!root_folder.exists()) {
    println('Folder not found: ' + root_folder.absolutePath)
    return
}

log_files.delete()
log_instruction.delete()
log_retry.delete()
instruction.delete()

println("Create the upload ftp_script and start it.")
ftp_script.withWriter('UTF-8') {
    it.writeLine 'option batch continue'
    it.writeLine 'option confirm off'
    it.writeLine 'option transfer binary'
    it.writeLine 'option reconnecttime 5'
    it.writeLine 'open ' + System.getenv()['FTP']
    it.writeLine 'lcd ' + root_folder.absolutePath.replaceAll('/', '\\')
    it.writeline 'put ' + folder
    it.writeline 'close'
    it.writeline 'exit'
}

run_app(System.getenv()['WinSCP'], '/console /script=' + ftp_script.absolutePath + ' /parameter ' + folder + ' /log=' + log_files.absolutePath.replaceAll('/', '\\'))
retry(folder, ftp_script, log_files)

println("Produce instruction")
run_app('groovy', System.getenv()['SORIMPORT_HOME'] + '/src/main/flow2/instruction.groovy -na ' + System.getenv()['NA'] + ' -fileSet ' + root_folder.absolutePath + ' -autoIngestValidInstruction true -label "flow2_' + folder + '" -notificationEMail lwo@iisg.nl')

println("Upload the instruction.")
ftp_script.delete()
ftp_script.withWriter('UTF-8') {
    it.writeLine 'option batch continue'
    it.writeLine 'option confirm off'
    it.writeLine 'option transfer binary'
    it.writeLine 'option reconnecttime 5'
    it.writeLine 'open ' + System.getenv()['FTP']
    it.writeLine 'lcd ' + root_folder.absolutePath.replaceAll('/', '\\')
    it.writeline 'put ' + folder + '\\instruction.xml ' + folder + '/instruction.xml'
    it.writeline 'close'
    it.writeline 'exit'
}

run_app(System.getenv()['WinSCP'], '/console /script=' + ftp_script.absolutePath + ' /parameter ' + folder + ' /log=' + log_files.absolutePath.replaceAll('/', '\\'))
retry(folder, ftp_script, log_files)

def run_app(String executable, String _arg = null) {
    def ant = new AntBuilder()
    try {
        ant.exec(outputproperty: "cmdOut",
                errorproperty: "cmdErr",
                resultproperty: "cmdExit",
                failonerror: "true",
                executable: executable) {
            if (_arg) arg(line: """$_arg""")
        }
    } catch (Exception e) {
        println(e.message)
    }
}

/**
 * There are always one or more files that failed to transport properly.
 * We will use the log to detect such events.
 *
 * @param log
 * @return 0=ok, 1 = retry, -1 = failure
 */
int retry(String folder, File ftp_script, File log_files, int limit = 10) {

    ftp_script.delete()
    ftp_script.withWriter('UTF-8') {
        it.writeLine 'option batch continue'
        it.writeLine 'option confirm off'
        it.writeLine 'option transfer binary'
        it.writeLine 'option reconnecttime 5'
        it.writeLine 'open ' + System.getenv()['FTP']
    }

    run_app(System.getenv()['SORIMPORT_HOME'] + '/src/main/flow2/retry.groovy', ftp_script.absolutePath + ' ' + log_files.absolutePath )
    if (ftp_script.exists()) {
        run_app(System.getenv()['WinSCP'], '/console /script=' + ftp_script.absolutePath + ' /parameter ' + folder + ' /log=' + log_files.absolutePath.replaceAll('/', '\\'))
        if (limit > 0)
            return retry(folder, ftp_script, log_files, limit - 1)
        else
            return -1
    }
    0
}