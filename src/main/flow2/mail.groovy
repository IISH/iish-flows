import javax.mail.internet.MimeMessage
import javax.mail.Session
import javax.mail.internet.InternetAddress
import javax.mail.Transport


File m = new File(args[0])
def message = m.name + '\n\n'
m.eachLine {
	message+=it
	message+='\n'
}

subject = "Sor import"
toAddress = "jzu@iisg.nl;gcu@iisg.nl;lwo@iisg.nl"
fromAddress = "flow2.be0.iisg.net@iisg.nl"
host = "mailrelay2.iisg.nl"
port = "25"

Properties mprops = new Properties()
mprops.setProperty("mail.transport.protocol", "smtp")
mprops.setProperty("mail.host", host)
mprops.setProperty("mail.smtp.port", port)

Session lSession = Session.getDefaultInstance(mprops, null)
MimeMessage msg = new MimeMessage(lSession)

//tokenize out the recipients in case they came in as a list
StringTokenizer tok = new StringTokenizer(toAddress, ";")
ArrayList emailTos = new ArrayList()
while (tok.hasMoreElements()) {
    emailTos.add(new InternetAddress(tok.nextElement().toString()))
}
InternetAddress[] to = new InternetAddress[emailTos.size()]
to = (InternetAddress[]) emailTos.toArray(to)
msg.setRecipients(MimeMessage.RecipientType.TO, to)
InternetAddress fromAddr = new InternetAddress(fromAddress)
msg.setFrom(fromAddr)
msg.setFrom(new InternetAddress(fromAddress))
msg.setSubject(subject)
msg.setText(message)

Transport transporter = lSession.getTransport("smtp")
transporter.connect()
transporter.send(msg)