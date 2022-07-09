from sys import path, stderr

try:
    path.insert(1, '../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, stderr)

"""
    Tests if domains are read from the configuration

"""

expected_data = {
    'app1': 'app1.company.com',
    'app2': 'app2.company.com'
}

if __name__ == '__main__':
    python_validator(expected_data)
