# Selenium
import time
import chromedriver_binary
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.remote.remote_connection import LOGGER
from selenium.common.exceptions import NoSuchElementException   
from selenium.common.exceptions import ElementNotSelectableException
from selenium.common.exceptions import NoAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import JavascriptException
from selenium.common.exceptions import ElementNotInteractableException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

# Selenium Settings
opts = Options()
opts.add_argument('--headless')

username_path = "//input[contains(@data-testid, 'username')]"
password_path = "//input[contains(@data-testid, 'password')]"
connect_path = "//button[contains(@data-testid, 'connect')]"
newpw_path = "//input[contains(@data-testid, 'newPassword')]"
cfm_newpw_path = "//input[contains(@data-testid, 'newPasswordConfirmation')]"
changepw_path = "//button[contains(@data-testid, 'changePassword')]"

browser = webdriver.Chrome(options=opts)
browser.get('http://localhost:7474/browser/')

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, username_path)))
element.clear()
element.send_keys("neo4j")

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, password_path)))
element.send_keys("neo4j")

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, connect_path)))
element.click()

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, newpw_path)))
element.send_keys("neo4jj")

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, cfm_newpw_path)))
element.send_keys("neo4jj")

element = WebDriverWait(browser, 5).until(
EC.element_to_be_clickable((By.XPATH, changepw_path)))
element.click()

time.sleep(2)
browser.quit()