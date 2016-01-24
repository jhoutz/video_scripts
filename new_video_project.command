#! /bin/bash

# Creates a Mac sparsebundle with directories for video project organization

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

BASEDIR=$(dirname $0)
cd $BASEDIR
eval $(parse_yaml settings.yml "config_")

# Reading settings values from settings.yml
NLE=$(echo $config_settings_editor)
MG=$(echo $config_settings_motion_graphics)
AUDIO=$(echo $config_settings_audio)
COLOR=$(echo $config_settings_coloring)
PROXY=$(echo $config_settings_create_proxy_folders)

# A li'l welcome and thank you. :)
printf "\n\n"
echo "Thanks for downloading this script! Hopefully it makes your life a little easier!"
echo "For more information about me, visit http://justinhoutz.com"
echo "Or email me at justin@justinhoutz.com"
printf "\n\n"

read -p "Type the name of your project and press ENTER: " IMAGE
read -p "Type the initial size of your disk image and press ENTER (ex. 200m, 20g): " SIZE

# Lowercase sparsebundle disk image name and replace spaces with underscores
# Default name = "video_project"
[ -n "$IMAGE" ] || IMAGE="video_project"
IMAGE=$(echo $IMAGE | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

# Create the sparsebundle disk image
# Default size = "1g"
if [ -z "$SIZE" ]; then SIZE="1g";fi
hdiutil create -type SPARSEBUNDLE -size $SIZE -fs HFS+ -volname $IMAGE $IMAGE

# Mount the sparsebundle disk image
hdiutil attach $IMAGE.sparsebundle

# Set current directory to var
CURR_LOC="$(pwd)"

# Navigate to sparsebundle disk image
cd /Volumes/$IMAGE

# Set defaults if no input given
if [ -n "$NLE" ]; then NLE="premiere"; else NLE=$(echo $NLE | tr '[:upper:]' '[:lower:]' | tr ' ' '_');fi
if [ -n "$MG" ]; then MG="after_effects"; else MG=$(echo $MG | tr '[:upper:]' '[:lower:]' | tr ' ' '_');fi
if [ -n "$AUDIO" ]; then AUDIO="audition"; else AUDIO=$(echo $AUDIO | tr '[:upper:]' '[:lower:]' | tr ' ' '_');fi
if [ -n "$COLOR" ]; then COLOR="resolve"; else COLOR=$(echo $COLOR | tr '[:upper:]' '[:lower:]' | tr ' ' '_');fi

# Create directories based on user input
mkdir $(echo $NLE | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
mkdir $(echo $MG | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
mkdir $(echo $AUDIO | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
mkdir $(echo $COLOR | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

# Create renders directory in NLE directory
cd $NLE
mkdir render
cd ..

# Create renders directory in motion graphics directory
cd $MG
mkdir render
cd ..

# Create renders directory in color applicaiton directory
cd $COLOR
mkdir render
cd ..

# Create raw directory
mkdir raw

# Navigate into raw directory
cd raw

# Create raw subdirectories
mkdir video
mkdir audio
cd audio
mkdir foley
mkdir music
mkdir dual_system
cd ..
mkdir photo

# Create source and proxy folders
if [[ "$PROXY" == true ]];then
  cd video
  mkdir source
  mkdir proxy
fi

# Move sparsebundle disk image to the desktop
mv $CURR_LOC/$IMAGE.sparsebundle ~/Desktop