"""
Rental application for the Glasgow University Fencing Club
"""

import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, TOP, BOTTOM
import xata

xata_cli = xata.XataClient(db_url="https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental", api_key="xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1")


class GUFCRentalApp(toga.App):

    def startup(self):
        main_box = toga.Box(style=Pack(direction=ROW, alignment=BOTTOM))

        # name_label = toga.Label(
        #     "Your name: ",
        #     style=Pack(padding=(0, 5))
        # )
        # self.name_input = toga.TextInput(style=Pack(flex=1))

        # name_box = toga.Box(style=Pack(direction=ROW,  padding=5))
        # name_box.add(name_label)
        # name_box.add(self.name_input)

        # main_box.add(name_box)
        button = toga.Button(
            "Say Hello!",
            on_press=self.say_hello,
            style=Pack(flex = 0)
        )

        
        table = toga.DetailedList(
            data=[
                {
                "icon": None,
                "title": "Arthur Dent",
                "subtitle": "Where's the tea?"
                },
                {
                "icon": None,
                "title": "Ford Prefect",
                "subtitle": "Do you know where my towel is?"
                },
                {
                "icon": None,
                "title": "Tricia McMillan",
                "subtitle": "What planet are you from?"
                },
            ]
        )

        button1 = toga.Button(
            "Klack!",
            on_press=self.say_hello,
            style=Pack(flex = 0)
        )

   
        # main_box.add(table)
        # main_box.add(button)

        # main_box.add(button1)
        self.main_window = toga.MainWindow(title=self.formal_name)
        self.main_window.content = main_box
        self.main_window.show()

    def say_hello(self, widget):
        resp = xata_cli.data().query("equipment_types")
        # print(resp)


def main():
    return GUFCRentalApp()
