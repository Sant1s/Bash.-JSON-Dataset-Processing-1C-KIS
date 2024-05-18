#!/usr/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)
            input_file=$2
            shift 2
            ;;
        --output)
            output_file=$2
            shift 2
            ;;
        --width)
            width=$2
            shift 2
            ;;
        --height)
            height=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done


if [[ -z "$input_file" || -z "$output_file" || -z "$width" || -z "$height" ]]; then
    echo "Usage: ./get_size.sh --input <file name> --width <number> --height <number> --output <file name>"
    exit 1
fi

if [ -f "$input_file" ]; then
    if [ "${input_file##*.}" != "json" ]; then
        echo "wrong file extension"
        exit
    fi
else
    echo """$input_file"" file does not exists or it's not file"
    exit
fi

REGEX="^[0-9]+$"
if [[ ! "$height" =~ $REGEX ]]; then
    echo "Invalid argument: height is not a number"
    exit 1
fi

if [[ ! "$width" =~ $REGEX ]]; then
    echo "Invalid argument: width is not a number"
    exit 1
fi

filtered_images=$(jq --argjson min_height "$height" --argjson min_width "$width" '[
    .images[] | select(.height <= $min_height and .width <= $min_width)]
' "$input_file")

for image in "${filtered_images[@]}"; do
    echo "{\"images\": ""$image""}" > "$output_file"
done



