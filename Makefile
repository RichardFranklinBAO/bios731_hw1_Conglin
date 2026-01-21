# Makefile
.PHONY: docker-build docker-report report clean help

IMG = richardfbao/d550-final-report:latest

docker-build:
	docker build --platform=linux/amd64 -t $(IMG) .

# 评分使用的目标：挂载本地 report/，生成报告到本地
docker-report:
	mkdir -p report
	docker run --rm --platform=linux/amd64 \
		-v "$(PWD)":/work \
		-v "$(PWD)/report":/out \
		-w /work \
		-e OUTDIR=/out \
		-e RENV_CONFIG_AUTOLOADER_ENABLED=FALSE \
		-e IN_DOCKER=true \
		$(IMG)



# 便捷别名
report: docker-report

clean:
	rm -rf report
	rm -rf data/clean

help:
	@echo "make docker-build  # building docker"
	@echo "make report        # generating report to ./report/R_Project.pdf"
	@echo "make clean         # deleting report/"
