import subprocess


def say_hello(name):
    result = subprocess.run(
        ["cowsay", f"hello, {name}!"], 
        capture_output=True, 
        text=True, 
        check=True
    )
    print(result.stdout)