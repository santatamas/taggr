tag:
	sh tagger.sh

clean:
	git tag | xargs git tag -d