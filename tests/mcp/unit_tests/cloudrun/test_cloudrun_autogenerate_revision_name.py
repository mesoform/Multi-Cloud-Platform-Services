from sys import path, stderr

try:
    path.insert(1, '../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, stderr)

"""
    Tests that autogenerate_revision_name is set as follows:
        - autogenerate_revision_name=true if there is nothing specified in template.metadata.name
        - autogenerate_revision_name=false if autogenerate_revision_name attribute is set to false in gcp_cloudrun.yml
        - autogenerate_revision_name=false if template.metadata.name is specified, 
          regardless of what autogenerate_revision_name is set to in gcp_cloudrun.yml
    set to false if a revision name is specified in template.metadata.name 

"""

expected_data = {
    'app1-service': 'true',
    'app2': 'false',
    'app1': 'false'


}

if __name__ == '__main__':
    python_validator(expected_data)
