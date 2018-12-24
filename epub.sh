#!/bin/bash

f_rotate(){
	for f in * 
	do
		bn="${f%.*}"
		en="${f##*.}"
		case "$en" in
			"png" | "tif" | "jpg" | "jpeg" | "bmp" | "gif" ) mogrify -rotate 90 ${bn}.${en} ;;
			*) continue ;;
		esac
	done
}




f_split(){
	 mkdir split_org
	 for f in *
	 do
		 bn="${f%.*}"
		 en="${f##*.}"
		 case "$en" in
			 "png" | "tif" | "jpg" | "jpeg" | "bmp" | "gif" )
						ow=$(identify -format '%w' ${bn}.${en})
						oh=$(identify -format '%h' ${bn}.${en})
						cw=`expr ${ow} / 2`
						convert -crop ${cw}x${oh} ${bn}.${en} ${bn}.bmp
						mv ${bn}-0.bmp ${bn}-b.bmp
						mv ${bn}-1.bmp ${bn}-a.bmp
						rm ${bn}-2.bmp
						mv ${bn}.${en} ./split_org
			 ;;
			 *) continue;;
		 esac
	 done
	 mogrify -format jpg *.bmp
	 rm *.bmp
}




f_epub(){
	#-mkdir
	# orgは元データを保持する
	mkdir -p org
	mkdir -p epub/META-INF
	mkdir -p epub/OEBPS/image

	#-Setting
	echo -n "IMG_QUALITY(1~100) : " && read IMG_QUALITY 
	echo -n "TITLE : " && read TITLE
	AUTHOR=`whoami`
	DATA=`date "+%s"`
	BOOKID=`echo urn:uuid:${DATA}.${AUTHOR}.kawadumax`
	CNT=0

	# 同じフォルダのファイルをjpegに変換する部分
	for f in *
	do
		bn="${f%.*}"
		en="${f##*.}"
		case "$en" in
			"png" | "tif" | "bmp" | "gif" )
					mogrify -format jpg -quality $IMG_QUALITY "${bn}.${en}"
					# もとの画像を保持の為に移す
					mv "${bn}.${en}" ./org
			;;
			"jpeg" | "jpg" )
					# mv ${bn}.${en} ./org/${bn}.${en}
					mv "${bn}.${en}" ./org
					# cp ./org/${bn}.${en} `echo ${bn}.jpg | tr ' ' '_'`
					cp "./org/${bn}.${en}" "./${bn}.jpg"
			;;
			*) continue;;
		esac
	done

	 mv *.jpg epub/OEBPS/image

	 cd epub
	 echo -n 'application/epub+zip' > mimetype
	 cd  META-INF
	 cat <<EOS > container.xml
<?xml version="1.0" ?>
	<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
		<rootfiles>
			<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
		</rootfiles>
	</container>
EOS
	 cd ../


	 cd OEBPS/image

	 for f in *
	 do
		 bn="${f%.*}"
		 en="${f##*.}"
		 case "$en" in
			 "jpg" )
				cat  <<EOS > ${bn}.xhtml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="ja">
<head>                                   
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />   
		<link rel="stylesheet" type="text/css" href="style.css" />                 
		<title>${bn}</title>                                                          
</head>                 
<body>                                                          
<div><img src="image/${bn}.${en}" alt="${bn}" class="content" /></div>                  
</body>                    
</html>
EOS

						 echo "<item id=\"${bn}.${en}\" href=\"image/${bn}.${en}\" media-type=\"image/jpeg\" />" >> content.opf.img
			 ;;
			 *) continue;;
		 esac
	 done

	 mv *.xhtml  ../
	 mv content.opf.img ../
	 cd ../

		cat <<EOS > content.opf
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" prefix="rendition: http://www.idpf.org/vocab/rendition/#" unique-identifier="BookID" version="3.0" xml:lang="ja">
	<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
		<dc:identifier id="BookID">$BOOKID</dc:identifier>
		<meta refines="#BookID" property="identifier-type">uuid</meta>
		<dc:title id="title0">$TITLE</dc:title>
		<dc:language id="language0">ja</dc:language>
		<dc:creator id="creator0">$AUTHOR</dc:creator>
		<meta refines="#creator0" property="role">aut</meta>
		<dc:description id="description0">description</dc:description>
		<dc:type id="type0">type</dc:type>
		<dc:publisher id="publisher0">自炊</dc:publisher>
		<dc:rights id="rights0">自炊</dc:rights>
		<dc:date>2013-04-29T00:00:00Z</dc:date>
		<meta property="dcterms:modified">2013-04-28T00:00:00Z</meta>
		<meta name="cover" content="cover.jpg" />
	</metadata>
	<manifest>
EOS

	cat <<EOS > toc.ncx
<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
	xmlns="http://www.daisy.org/z3986/2005/ncx/"
	version="2005-1"
	xml:lang="ja">
	<head>                                                                   
		 <meta name="dtb:uid" content="$BOOKID" />                                                                
		 <meta name="dtb:depth" content="1" />                                                                
		 <meta name="dtb:totalPageCount" content="0" />                                                        
		 <meta name="dtb:maxPageNumber" content="0" />                                                         
	</head>
	<docTitle>
		 <text>$TITLE</text>
	</docTitle>
	<navMap>
EOS

	for f in *
		do
		 	bn="${f%.*}"
		 	en="${f##*.}"
		 	case "$en" in
			 	"xhtml" )
					echo "<item id=\"${bn}\" href=\"${bn}.${en}\" media-type=\"application/xhtml+xml\" />" >> content.opf
			 	;;
			 	*) continue;;
		 	esac
	 	done

	 	cat content.opf.img >> content.opf
	 	rm  content.opf.img

	 	cat <<EOS >> content.opf
<item properties="nav" id="nav" href="nav.xhtml" media-type="application/xhtml+xml" />
<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
<item id="style" href="style.css" media-type="text/css" />
</manifest>
<spine page-progression-direction="rtl" toc="ncx">
EOS

	cat <<EOS > nav.xhtml
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja">
	<head>
		<title>目次</title>
	</head>
	<body>
		<nav xmlns:epub="http://www.idpf.org/2007/ops" epub:type="toc">
			<h1>$TITLE</h1>
			<ol>
				<li><a>目次はないです</a></li>
			</ol>
		</nav>
	</body>
</html>
EOS

	 	for f in *
	 	do
		 bn="${f%.*}"
		 en="${f##*.}"
		 case "$en" in
			 "xhtml")
					 CNT=`expr $CNT + 1`

					 echo "<itemref idref=\"${bn}\" />"                                          >> content.opf
					 echo "<navPoint id=\"${bn}\" playOrder=\"$CNT\">"                           \
								"    <navLabel>"                                                       \
								"        <text>Page $CNT</text>"                                       \
								"    </navLabel>"                                                      \
								"    <content src=\"${bn}.${en}\" />"                                  \
								"</navPoint>"                                                          >> toc.ncx
			 ;;
			 *) continue;;
		 esac
	 done

	echo "</spine></package>" >> content.opf
	echo "</navMap></ncx>"   >> toc.ncx

	cat <<EOS > style.css
body {
	text-align: center; 
	margin: 0px;
	padding: 0px;
}

div {
	margin:0px;
	padding:0px;
}

img.content {
	margin:0px;
	padding:0px;
	max-width: 100%;
	height: auto;
}
EOS

	 cd ../

	 #-GO!
	zip -0X ../${TITLE}.epub mimetype
	zip -r9X ../${TITLE}.epub * -x mimetype

	 cd ..
	 rm -rf epub
	 mv  org/* ./
	 rm -rf org

	 echo "--- DONE!"

}


#-default option
if [ -z $1 ]; then  mode="epub";    else  mode=$1; fi

#-switch option
case "$mode" in
		"epub"  ) echo "epub";;
		"split" ) echo "split";;
		"rotate") echo "rotate";;
		 *      ) mode="epub";;
esac

#-Go!
f_${mode}