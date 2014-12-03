import sys
import json
import subprocess
import base64
import cStringIO
from PIL import Image
from libmproxy.protocol.http import decoded

def response(context, flow):
    content_type = flow.response.headers.get_first("content-type", "")
    if "text/html" in content_type:
        json_response = {}
        # sys.stdout.write("Content Type: "+ content_type +"\n\n")
        sys.stdout.write("\n\n")
        sys.stdout.write("----- RESPONSE -----")
        sys.stdout.write("----- URL -----")
        url = flow.request.scheme + "//" + flow.request.host + flow.request.path
        json_response['url'] = url
        sys.stdout.write(url)
        sys.stdout.write("----- URL -----")
        sys.stdout.write("\n\n")
        sys.stdout.write("----- HEADERS -----")
        json_response['headers'] = {}
        for k, v in flow.response.headers.items():
            json_response['headers'][k] = v
        sys.stdout.write(json.dumps(json_response['headers']))
        sys.stdout.write("----- HEADERS -----")

        sys.stdout.write("\n\n")
        sys.stdout.write("----- BODY -----")
        json_response['body'] = flow.response.content
        sys.stdout.write(flow.response.content)
        sys.stdout.write("----- BODY -----")
        sys.stdout.write("----- RESPONSE -----")
        sys.stdout.write("\n\n")
        sys.stdout.write("---------------------------------------------------")
        encoded_data = base64.b64encode(json.dumps(json_response))
        subprocess.call("/Users/fernyb/scripts/lwes_emit.rb '"+ encoded_data +"'", shell=True)
        # with decoded(flow.response):
        #     try:
        #         s = cStringIO.StringIO(flow.response.content)
        #         sys.stdout.write("Response Content: "+ s +"\n\n")
        #     except:
        #         pass
