import asyncio
import getpass

from traitlets.config import Config
from ldapauthenticator import LDAPAuthenticator

# Configure LDAPAuthenticator below to work against your ldap server
c = Config()
c.LDAPAuthenticator.server_address = "ldap.uni-rostock.de"
c.LDAPAuthenticator.server_port = 636
c.LDAPAuthenticator.bind_dn_template = "uid={username},ou=people,dc=uni-rostock,dc=de"
c.LDAPAuthenticator.user_attribute = "uid"
c.LDAPAuthenticator.user_search_base = "ou=people,dc=uni-rostock,dc=de"
c.LDAPAuthenticator.attributes = ["uid", "cn", "ou", "o"]
# The following is an example of a search_filter which is build on LDAP AND and OR operations
# here in this example as a combination of the LDAP attributes 'ou', 'mail' and 'uid'
sf = "(&(o={o})(ou={ou}))".format(o="uni-rostock", ou="people")
#sf += "(&(o={o})(mail={mail}))".format(o="yourOrganisation", mail="yourMailAddress")
c.LDAPAuthenticator.search_filter = f"(&({{userattr}}={{username}})(|{sf}))"

# Run test
authenticator = LDAPAuthenticator(config=c)
username = input("Username: ")
password = getpass.getpass()
data = dict(username=username, password=password)
return_value = asyncio.run(authenticator.authenticate(None, data))
print(return_value)