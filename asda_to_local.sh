if [ -z "$1" -o ! -d "$1" \
     -o ! -f "$1/wwwroot/htmlTemplates/pages/common/common-config.shtml" \
	 -o ! -f "$1/wwwroot/htmlTemplates/components/document_head.shtml" \
	 -o ! -d "$1/wwwroot/assets/theme_default/style" ]
then
	echo "Enter a valid directory to modify"
	echo
	exit
fi

cd $1

# Configuring for local usage
sed -i 's/useMinifiedFiles" value="true/useMinifiedFiles" value="false/' wwwroot/htmlTemplates/pages/common/common-config.shtml
sed -i 's/useImageServer" value="true/useImageServer" value="false/' wwwroot/htmlTemplates/pages/common/common-config.shtml
sed -i 's/cssBasePath" value="${HTTP_cssBasePath/cssBasePath" value="\/\/${HTTP_HOST/' wwwroot/htmlTemplates/pages/common/common-config.shtml

# Fixing a small bug
sed -i 's/allContentStyle_1506/allContentStyle_1504/' wwwroot/htmlTemplates/components/document_head.shtml

#Get responsive CSS files to local
mkdir wwwroot/assets/theme_default/style/min
mkdir wwwroot/assets/theme_default/style/min/responsive
cd wwwroot/assets/theme_default/style/min/responsive
wget http://ui1.assets-asda.com/theme/style/min/responsive/signin.css
wget http://ui1.assets-asda.com/theme/style/min/responsive/responsive.css
wget http://ui1.assets-asda.com/theme/style/min/responsive/responsiveGlobal.css

# Integrating PerfLogger library to local web repository
cd $1/wwwroot/assets/lib/
wget --no-check-certificate https://raw.githubusercontent.com/tomjbarker/perfLogger/master/perfLogger.js
sed -i '25i\
\t\t<script src="<!--#echo var="jsBasePath"-->\/lib\/perfLogger.js"><\/script>\r\
\t\t<style>#debug {display: block!important;}<\/style>\r' $1/wwwroot/htmlTemplates/components/body_footer.shtml