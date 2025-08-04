import sys
import platform
import datetime

def test_python():
    try:
        # Print Python version and platform info
        print(f"Python Version: {sys.version}")
        print(f"Platform: {platform.platform()}")

        # Basic arithmetic test
        test_calc = 2+2
        print(f"Basic calculation (2+2): {test_calc}")

        # String manipulation test
        test_string = "Hello, Python!"
        print(f"String test: {test_string.upper()}")

        # Current timestamp test
        current_time = datetime.datetime.now()
        print(f"Current time: {current_time}")

        # Basic file operation test
        with open("test.txt","w") as f:
            f.write("Python test successful!")
        with open("test.txt","r") as f:
            content = f.read()
        print(f"File I/O test: {content}")

        print("\nAll tests completed successfully!")

    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__=="__main__":
    test_python()