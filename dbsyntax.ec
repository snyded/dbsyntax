/*
    dbsyntax.ec - checks the syntax of SQL statements
    Copyright (C) 1993  David A. Snyder
 
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; version 2 of the License.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef lint
static char sccsid[] = "@(#) dbsyntax.ec 1.0  93/12/24 20:19:03";
#endif /* not lint */


#include <stdio.h>
$include sqlca;

#define SUCCESS 0

char	*database = NULL;
extern char	*optarg;
extern int	optind, opterr;

/* ARGSUSED */
main(argc, argv)
int	argc;
char	*argv[];
{
	$char	buf[4096], exec_stmt[32];
	int	c, dflg = 0, errflg = 0;
	void	perror();


	/* Print copyright message */
	(void)fprintf(stderr, "DBSYNTAX version 1.0, Copyright (C) 1993 David A. Snyder\n\n");

	/* get command line options */
	while ((c = getopt(argc, argv, "d:")) != EOF)
		switch (c) {
		case 'd':
			dflg++;
			database = optarg;
			break;
		default:
			errflg++;
			break;
		}

	/* validate command line options */
	if (errflg || !dflg) {
		(void)fprintf(stderr, "usage: %s -d dbname [files...]\n", argv[0]);
		exit(1);
	}

	/* locate the database in the system */
	sprintf(exec_stmt, "database %s", database);
	$prepare db_exec from $exec_stmt;
	$execute db_exec;
	if (sqlca.sqlcode != SUCCESS) {
		(void)fprintf(stderr, "Database not found or no system permission.\n\n");
		exit(1);
	}

	for (c = 0; c < optind; c++, *++argv) ;
	if (!*argv)
		process(argc, *argv, buf);
	else
		do {
			if (!freopen(*argv, "r", stdin)) {
				perror(*argv);
				continue;
			}
			process(argc, *argv, buf);
		} while (*++argv);
	return(0);
}


process(argc, argv, buf)
int	argc;
char	*argv, *buf;
{
	$char	*s1, s2[BUFSIZ], msg[BUFSIZ];

	s1 = buf;
	while ((*s1 = getchar()) != EOF) {
		switch (*s1++) {
		case '{':
			*s1--;
			while ((*s1 = getchar()) != '}')
				;
			break;
		case ';':
			*s1 = '\0';
			s1 = buf;
			$prepare stmtid from $s1;
			if (sqlca.sqlcode != SUCCESS) {
				if (*argv && argc - optind > 1)
					(void)printf("%s: ", argv);
				(void)rgetmsg(sqlca.sqlcode, msg, sizeof(msg));
				(void)sprintf(s2, msg, sqlca.sqlerrm);
				(void)printf("%s\n%s\n\n", s1, s2);
			}
			break;
		}
	}
}


