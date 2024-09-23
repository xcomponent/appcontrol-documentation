
import shutil
import os

def copy_images(*args, **kwargs):
    # Get the current script's directory
    current_dir = os.path.dirname(os.path.abspath(__file__))

    # Define source and destination directories
    source_dir =  os.path.join(current_dir, 'en', 'images')
    destination_dir = os.path.join(current_dir, '..', 'site', 'en', 'assets', 'images')

    # Create the destination directory if it doesn't exist
    os.makedirs(destination_dir, exist_ok=True)

    # Copy files from the source to the destination
    shutil.copytree(source_dir, destination_dir, dirs_exist_ok=True)

    print(f"Copied images from {source_dir} to {destination_dir}")
