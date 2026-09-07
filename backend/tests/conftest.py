import os
import sys

# Make `app` importable when tests run from the backend directory.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
