/**
 * Validate Sru
 *
 * Make sure the identifier exists in our metadata.
 */

class statusSru {

    private def orAttributes

    public statusSru(def args) {
        orAttributes = args
        println("Loaded class statusSru { class with arguments:")
        println(orAttributes)
    }

    void start() {
        def xml = callSru(orAttributes.marc_852_p)
        String df_542m = xml?.'**'?.find { it.@tag == '452' }?.subfield?.find {
            it.'@code' == 'm'
        }?.text() ?: ACCESS_DEFAULT
    }

    /**
     * callSru
     *
     * Ask for a record and return the 001 field.
     *
     * @param pid
     * @return
     */
    private def callSru(String _marc852p) {

        def sb = new StringBuilder(orAttributes.sruServer)
                .append('?query=')
                .append(URLEncoder.encode('marc.852$p=\"' + _marc852p + '\"', "UTF-8"))
                .append('&version=1.1')
                .append('&operation=searchRetrieve')
                .append('&recordSchema=info:srw/schema/1/marcxml-v1.1')
                .append('&maximumRecords=1')
                .append('&startRecord=1')
                .append('&resultSetTTL=0')
                .append('&recordPacking=xml')

        new XmlSlurper().parse(sb.toString())
    }

}


def arguments = [:]
for (int i = 0; i < args.length; i++) {
    if (args[i][0] == '-') {
        arguments.put(args[i].substring(1), args[i + 1])
    }
}

["sruServer", "marc_852_p"].each {
    assert arguments[it], "Need required argument -$it [value]"
}

def instruction = new statusSru(arguments)
instruction.start()