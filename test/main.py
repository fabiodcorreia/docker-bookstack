import sys
import mechanize

APP_TEST_PORT = "80"

assert len(sys.argv) > 1, "no arguments"

APP_TEST_URL = sys.argv[1]

print("TEST_URL=" + APP_TEST_URL)

def setFormInput(form, input, val):
  form.find_control(input).value = val

def tryFollowLink(link):
  try:
    response = br.follow_link(link)
    assert response.code == 200, "response for " + link.url + " was " + response.code
    return response
  except:
    assert False, "Fail to follow link to : " + link.url

br = mechanize.Browser()
br.set_handle_robots(False)

response = br.open(APP_TEST_URL)
assert response.code == 200, "response code is not 200"
assert response.geturl() == APP_TEST_URL+"/login", "initial page is not /login: " + response.read()

forms = list(br.forms())

assert len(forms) == 1, "login form not found"

br.form = forms[0]

setFormInput(br.form, "email", "admin@admin.com")
setFormInput(br.form, "password", "password")
response = br.submit()

assert response.code == 200, "response code is not 200"

response = tryFollowLink(br.find_link(text="View Profile"))

assert response.geturl() == APP_TEST_URL+"/user/1", "initial page is not /user/1: " + response.read()

print("Test completed with success")
