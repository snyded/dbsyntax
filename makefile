# makefile
# This makes "dbsyntax"

CC=esql
#CC=c4gl

dbsyntax: dbsyntax.ec
	$(CC) -O dbsyntax.ec -o dbsyntax -s
	@rm -f dbsyntax.c
