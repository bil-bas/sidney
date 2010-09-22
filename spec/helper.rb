require "rspec"
require "fileutils"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib", "sidney")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib", "sidney", "resources")

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))
LOG_PATH = File.join(ROOT_PATH, "logs")

DATA_DIR = File.join(ROOT_PATH, "test_data")

INPUT_DIR =  File.join(DATA_DIR, "input")
GENERATED_DIR = File.join(DATA_DIR, "generated")

CACHE_IN = File.join(INPUT_DIR, "resourceCache")
CACHE_OUT = File.join(GENERATED_DIR, "resourceCache")