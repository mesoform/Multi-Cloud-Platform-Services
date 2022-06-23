from sys import path, stderr

try:
    path.insert(1, '../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, stderr)

"""
    Tests that secrets are added to correct variable for the mount attachment type/
    Config structure should look like
    secrets:
      secret_1: 
        version: $Version
        mount_location: $Environent-variable-name 
        

"""

expected_data = {
    'secret_1': '/etc/location',
    'secret_3': '/etc/location/2'
}

if __name__ == '__main__':
    python_validator(expected_data)
