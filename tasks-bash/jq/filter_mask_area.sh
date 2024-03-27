#!/usr/bin/bash

function json_dataset_processing () {
    local category_id
    category_id=$(jq --arg name "$2" '.categories[] | select(.name == $name) | .id' "$1")
    local images_id
    images_id=$(jq --argjson cat_id "$category_id" '[.annotations[] | select(.category_id == $cat_id) | .image_id]' "$1")

    for image_id in $(echo "${images_id}" | jq -r '.[]'); do
        local image
        image="$(jq --argjson id "$image_id" --argjson area "$4" '.images[] | select((.id == $id) and (.height * .width >= $area))' "$1")"
        jq --argjson new_entry "$image" '.images += [$new_entry]' "$3" > temp.json && mv temp.json "$3"
    done
}


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
        --category)
            category=$2
            shift 2
            ;;
        --area)
            area=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done


if [[ -z "$input_file" || -z "$output_file" || -z "$category" ]]; then
    echo "Usage: ./get_category.sh --input <input name> --category <category name> --output <file name>"
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

echo '{"images": []}' > "$output_file"
json_dataset_processing "$input_file" "$category" "$output_file" "$area"