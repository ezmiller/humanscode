deploy:
	jekyll build
	rsync -avz --progress --delete-after _site/ humanscode:live/
	jekyll build --drafts
	rsync -avz --progress --delete-after --exclude '.htpasswd' _site/ humanscode:staging/

deploy-live:
	jekyll build
	rsync -avz --progress --delete-after _site/ humanscode:live/

deploy-drafts:
	jekyll build --drafts
	rsync -avz --progress --delete-after --exclude '.htpasswd' _site/ humanscode:staging/
