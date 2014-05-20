/**
 * harvest.groovy
 *
 * harvest a repository
 * create an instruction from it
 */

class Oai2Harvester {

    private def orAttributes
    def records = 0
    private def required = ['baseURL', 'verb']

    public Oai2Harvester(def args) {
        orAttributes = args
        println("Loaded harvester class with arguments:")
        println(orAttributes)

        required.each {
            assert orAttributes[it]
        }
    }

    void start() {

        String resumptionToken = " "
        int count = 0
        while (resumptionToken) {

            def sb = new StringBuilder(orAttributes.baseURL + '?verb=' + orAttributes.verb)
            if (resumptionToken.trim())
                sb.append('&resumptionToken=' + resumptionToken)
            else
                ['identify', 'from', 'until', 'set', 'metadataPrefix'].each {
                    if (orAttributes[it])
                        sb.append('&' + it + '=' + orAttributes[it])
                }

            def listRecords = new XmlSlurper().parse(sb.toString())?.'ListRecords'

            listRecords?.'record'?.'metadata'?.record?.each { record ->

                count++

                // Get the identifier
                String cf_001 = record.controlfield.find {
                    it.'@tag' == '001'
                }?.text()

                // Get the access code; 'closed' as default.
                String df_542m = record.datafield?.find {
                    it.'@tag' == '542'
                }?.subfield?.find {
                    it.'@code' == 'm'
                }?.text() ?: 'closed'

                // Get the barcodes.
                def barcodes = record.datafield?.inject([]) { visitor, it ->
                    def subfield = it.subfield?.find { it.'@code' == 'p' }
                    if ( subfield )
                        visitor << subfield.text()
                    visitor
                }

                println(cf_001 + ' ' + df_542m + ' ' + barcodes)

                resumptionToken = listRecords.resumptionToken
            }
        }
    }
}

def arguments = [:]
for (int i = 0; i < args.length; i++) {
    if (args[i][0] == '-') {
        arguments.put(args[i].substring(1), args[i + 1])
    }
}

def harvester = new Oai2Harvester(arguments)
println("Start...")
harvester.start()
println("Done. Processed " + harvester.records + " files.")