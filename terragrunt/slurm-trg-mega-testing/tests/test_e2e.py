import pytest
import tftest
import os
import time
import requests
import json
import yandexcloud


def wait_until(check, interval=60, timeout=900, *args):
    start = time.time()
    result = None
    while not result and time.time() - start < timeout:
        try:
            print(check)
            result = eval(check)
        except Exception as e:
            print(f"Skipping exception {e}")
            time.sleep(interval)
    return result


@pytest.fixture(scope="session")
def tg():
    test = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../test")
    tg = tftest.TerragruntTest(test, tg_run_all=True)
    tg.setup()
    tg.apply(output=False, tg_non_interactive=True)
    try:
        tg.apply(output=False, tg_non_interactive=True)
        yield tg.output()
    finally:
        tg.destroy(auto_approve=True, tg_non_interactive=True)


def test_web(tg):
    ip = [o["public_ip"] for o in tg if "public_ip" in o][0]
    response = wait_until(f"requests.get('http://{ip}')")
    assert response
    assert response.status_code == 200
    assert response.content == b"Hello from Yandex"


def test_api(tg):
    network_id_output = [o["network_id"] for o in tg if "network_id" in o][0]
    with open(os.environ["YC_SERVICE_ACCOUNT_KEY_FILE"], 'r') as creds:
        yc = yandexcloud.SDK(service_account_key=json.load(creds))
    network_id = yc.helpers.find_network_id(folder_id=os.environ["YC_FOLDER_ID"])
    assert network_id == network_id_output
