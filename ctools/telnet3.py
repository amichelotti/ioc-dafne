import asyncio

import click
from telnetlib3 import open_connection


@click.group()
def cli():
    pass


async def user_input(writer):
    loop = asyncio.events._get_running_loop()

    while True:
        # run the wait for input in a separate thread
        cmd = await loop.run_in_executor(None, input)
        writer.write(cmd)
        writer.write("\r")
        print(".", flush=True, end="")


async def server_output(reader):
    while True:
        out_p = await reader.read(1024)
        if not out_p:
            raise EOFError("Connection closed by server")
        print(out_p, flush=True, end="")


async def shell(reader, writer):
    # user input and server output in separate tasks
    tasks = [
        server_output(reader),
        user_input(writer),
    ]

    await asyncio.gather(*tasks)


async def runner(hostname, port):
    reader, writer = await open_connection(hostname, port, shell=shell)
    await writer.protocol.waiter_closed


@cli.command()
@click.argument("hostname", type=str)
@click.argument("port", type=int)
def connect(hostname, port):
    asyncio.run(runner(hostname, port))


cli.add_command(connect)
if __name__ == "__main__":
    cli()
