import click

from src import hello


@click.command()
@click.argument("name")
def main(name):
    hello.say_hello(name)