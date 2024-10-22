<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ehd="http://ehd.mos.com/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
    <s:Header>
        <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" s:actor="http://smev.gosuslugi.ru/actors/smev">
            <o:BinarySecurityToken u:Id="uuid-ee82d445-758b-42cb-996c-666b74b60022-2" ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">
                %(b64cert)s
            </o:BinarySecurityToken>
            <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
                <SignedInfo>
                    <CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
                    <SignatureMethod Algorithm="%(signMethod)s"/>
                    <Reference URI="#body">
                        <Transforms>
                            <Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
                        </Transforms>
                        <DigestMethod Algorithm="%(digestMethod)s"/>
                        <DigestValue></DigestValue>
                    </Reference>
                </SignedInfo>
                <SignatureValue></SignatureValue>
                <KeyInfo>
                    <o:SecurityTokenReference>
                        <o:Reference ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3" URI="#uuid-ee82d445-758b-42cb-996c-666b74b60022-2" />
                    </o:SecurityTokenReference>
                </KeyInfo>
            </Signature>
        </o:Security>
    </s:Header>
    <s:Body u:Id="body" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <ehd:setDataIn>
            <xml>%(body)s</xml>
        </ehd:setDataIn>
    </s:Body>
</s:Envelope>