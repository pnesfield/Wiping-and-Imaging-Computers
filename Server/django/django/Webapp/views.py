from django.views.decorators.csrf import csrf_exempt
import logging
import datetime
from django.http import HttpResponse
import urllib.parse
debug = False

logger = logging.getLogger(__name__)


@csrf_exempt
def asset(request):
    return_message = ""
    if request.method == 'POST':
        serial = request.body.decode()
        if debug: logger.warning("Lookup " + serial)
        try:
            f = open("Serials/" + serial + ".txt", "r")
            return_message = f.readline()
            f.close()
        except:
            pass
    else:
        return_message = "django record expected a POST"
        logger.warning(return_message)
    return HttpResponse(return_message)


@csrf_exempt
def log(request):
    try:
        return_message = "OK"
        if request.method == 'POST':
            if debug: logger.warning(request.body)
            body = request.body.decode()
            logger.warning(body)
            lines = body.splitlines()
            logger.warning(len(lines))
            if not lines[0].startswith("Asset"):
                return_message = "Error " + lines[0] + " Expected Asset:####"
                logger.warning("Error " + lines[0] + " Expected Asset:####")
            else:
                if not lines[1].startswith("State"):
                    return_message = "Error " + lines[1] + " Expected State:####"
                    logger.warning("Error " + lines[1] + " Expected State:####")
                else:
                    if "WipeMethod" in body:
                        f = open("Assets/" + lines[0][6:] + lines[1][6:] + ".log", "a")
                    else:
                        f = open("Assets/" + lines[0][6:] + lines[1][6:] + ".log", "w")
                    for line in lines:
                        # logger.warning("line " + line)
                        if ":" in line:
                            delim = line.find(":")
                            attribute = line[0:delim].strip()
                            value = line[delim + 1:].strip()
                            if debug: logger.warning(attribute + ":" + value)
                            f.write(attribute + ":" + value + "\n")
                    f.close()
                    if not lines[2].startswith("Serial"):
                        return_message = "Error: " + lines[2] + " Expected Serial:####"
                        logger.warning("Error: " + lines[2] + " Expected Serial:####")
                    else:
                        if not lines[2][7:].strip():
                            return_message = "Error: " + lines[2] + " blank Serial:####"
                            logger.warning("Error: " + lines[2] + " blank Serial:####")
                        else:
                                f = open("Serials/" + lines[2][7:] + ".txt", "w")
                                f.write(lines[0][6:])
                                f.close()
        else:
            return_message = "Error: django record expected a POST"
            logger.warning(return_message)
    except Exception as e:
        return_message = "Error: " + str(e)
    return HttpResponse(return_message)