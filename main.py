import uvicorn
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.responses import StreamingResponse, FileResponse
import secrets
import sys
sys.path.append('/app/pycades')
import pycades
from pydantic import BaseModel
import os
import xml_worker
import io

security = HTTPBasic()
SIG_PIN = os.environ['SIG_PIN']

def get_current_username(credentials: HTTPBasicCredentials = Depends(security)):
    correct_username = secrets.compare_digest(credentials.username, "user")
    correct_password = secrets.compare_digest(credentials.password, "MRo)(up6|NzmIe%0")
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="incorrect credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username


app = FastAPI(dependencies=[Depends(get_current_username)])


class Msg(BaseModel):
    text: str


@app.get("/")
async def root():
    return {"pycades version": pycades.ModuleVersion()}


@app.get("/list")
async def c_list():
    store = pycades.Store()
    store.Open(pycades.CADESCOM_CONTAINER_STORE, pycades.CAPICOM_MY_STORE, pycades.CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED)
    certs = store.Certificates
    return {"count": certs.Count}


@app.post("/sign_string")
async def sign_string(msg: Msg):
    store = pycades.Store()
    store.Open(pycades.CADESCOM_CONTAINER_STORE, pycades.CAPICOM_MY_STORE, pycades.CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED)
    certs = store.Certificates
    assert(certs.Count != 0), "Certificates with private key not found"

    signer = pycades.Signer()
    signer.Certificate = certs.Item(1)
    #signer.CheckCertificate = True
    signer.KeyPin = SIG_PIN

    signedData = pycades.SignedData()
    signedData.Content = msg.text
    signature = signedData.SignCades(signer, pycades.CADESCOM_CADES_BES)

    return {"result": signature}


@app.post("/sign_xml")
async def sign_xml(msg: Msg):
    store = pycades.Store()
    store.Open(pycades.CADESCOM_CONTAINER_STORE, pycades.CAPICOM_MY_STORE, pycades.CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED)
    certs = store.Certificates
    assert(certs.Count != 0), "Certificates with private key not found"

    signer = pycades.Signer()
    signer.Certificate = certs.Item(1)
    b64cert = certs.Item(1).Export(pycades.CADESCOM_ENCODE_BASE64)
    b64cert = b64cert.replace('\n', '')
    #signer.CheckCertificate = True
    signer.KeyPin = SIG_PIN

    signedXML = pycades.SignedXML()
    vrs = {
        'b64cert': b64cert,
        'signMethod': 'urn:ietf:params:xml:ns:cpxmlsec:algorithms:gostr34102012-gostr34112012-256',
        'digestMethod': 'urn:ietf:params:xml:ns:cpxmlsec:algorithms:gostr34112012-256',
        'body': msg.text
    }

    signedXML.Content = xml_worker.template('def.tpl', vrs)
    signedXML.SignatureType = pycades.CADESCOM_XML_SIGNATURE_TYPE_TEMPLATE
    signature = signedXML.Sign(signer)
    b = signature.encode()
    return StreamingResponse(io.BytesIO(b), media_type='text/plain')

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=80)
