from config import config_by_name

def test_config_environments():
    dev = config_by_name["development"]
    test = config_by_name["testing"]
    prod = config_by_name["production"]
    assert dev.DEBUG is True or dev.DEBUG is False
    assert test.TESTING is True
    assert prod.DEBUG is False
