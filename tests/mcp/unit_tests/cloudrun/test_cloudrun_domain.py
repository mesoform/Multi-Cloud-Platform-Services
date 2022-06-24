from sys import path, stderr

try:
    path.insert(1, '../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, stderr)

"""
    Tests that secrets are added to correct variable for the environment attachment type/
    Config structure should look like
    secrets:
      secret_1: 
        version: $Version
        env_name: $Environent-variable-name 
        

"""

expected_data = {
    'app1': 'app1.company.com',
    'app2': 'app2.company.com'
}

if __name__ == '__main__':
    python_validator(expected_data)
