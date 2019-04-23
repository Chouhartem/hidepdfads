all: hidepdfads

hidepdfads: src/script.sh presets.txt
	cat $^ > $@

presets.txt: data/presets.json
	jq --raw-output '.[] | (.name + " " + .X + " " + .Y + " " + .L + " " + .H + " " + .color + " " + .unit + " " + .format)' < "$^" > "$@"

clean:
	rm presets.txt

.PHONY: clean all
