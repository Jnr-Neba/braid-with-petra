#!/bin/bash

# Braid with Petra - HEAD Section Update Script
# Updates <head> section with SEO improvements and purple BP favicon

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  HEAD Section Update Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Change to project directory
cd ~/Desktop/Petra-web

# Check if index.html exists
if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ Error: index.html not found!${NC}"
    exit 1
fi

# Create backup
BACKUP_FILE="index.html.backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${BLUE}📋 Creating backup: ${BACKUP_FILE}${NC}"
cp index.html "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backup created${NC}"
else
    echo -e "${RED}❌ Failed to create backup${NC}"
    exit 1
fi

# Create new HEAD section
cat > /tmp/new-head-section.txt << 'NEWHEAD'
<head>
	<!-- Basic Meta Tags -->
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	
	<!-- Page Title (SEO Optimized) -->
	<title>Braid with Petra | Expert Braiding, Hair & Nail Services in Douala, Cameroon</title>
	
	<!-- Meta Description for Google Search -->
	<meta name="description" content="Professional braiding, hair styling, and beautiful nail art in Bonaberi, Douala. Specializing in box braids, cornrows, and expert beauty services. Book your appointment today!" />
	
	<!-- Keywords -->
	<meta name="keywords" content="braiding Douala, hair salon Cameroon, nail services Bonaberi, box braids, cornrows, hairstylist Douala, nail art Cameroon, beauty salon Douala, Braid with Petra" />
	
	<!-- Author -->
	<meta name="author" content="Braid with Petra" />
	
	<!-- Robots -->
	<meta name="robots" content="index, follow" />
	
	<!-- Canonical URL -->
	<link rel="canonical" href="https://www.braidwithpetra.ca" />
	
	<!-- Custom Purple BP Favicon (Her Favorite Color!) -->
	<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><circle cx='50' cy='50' r='48' fill='%23E8E3F3'/><circle cx='50' cy='50' r='48' fill='none' stroke='%23D4AF37' stroke-width='2'/><text x='50' y='63' font-family='Georgia,serif' font-size='40' font-weight='600' fill='%23667eea' text-anchor='middle' letter-spacing='1'>BP</text></svg>" />
	
	<!-- Open Graph / Facebook -->
	<meta property="og:type" content="website" />
	<meta property="og:url" content="https://www.braidwithpetra.ca" />
	<meta property="og:title" content="Braid with Petra - Expert Beauty Services in Douala" />
	<meta property="og:description" content="Professional braiding, hair styling, and nail art in Douala, Cameroon. Specializing in box braids, cornrows, and beautiful nail services." />
	<meta property="og:image" content="https://www.braidwithpetra.ca/images/braiding-1.jpg" />
	<meta property="og:locale" content="en_US" />
	<meta property="og:site_name" content="Braid with Petra" />
	
	<!-- Twitter Card -->
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:url" content="https://www.braidwithpetra.ca" />
	<meta name="twitter:title" content="Braid with Petra - Expert Beauty Services" />
	<meta name="twitter:description" content="Professional braiding, hair styling, and nail art in Douala, Cameroon" />
	<meta name="twitter:image" content="https://www.braidwithpetra.ca/images/braiding-1.jpg" />
	
	<!-- Mobile Theme Color (Purple to match favicon) -->
	<meta name="theme-color" content="#667eea" />
	
	<!-- Geo Tags for Local SEO -->
	<meta name="geo.region" content="CM-LT" />
	<meta name="geo.placename" content="Douala" />
	<meta name="geo.position" content="4.0511;9.7679" />
	<meta name="ICBM" content="4.0511, 9.7679" />
	
	<!-- Stylesheets -->
	<link rel="stylesheet" href="assets/css/main.css" />
	<noscript><link rel="stylesheet" href="assets/css/noscript.css" /></noscript>
	
	<!-- Schema.org Structured Data (Local Business) -->
	<script type="application/ld+json">
	{
		"@context": "https://schema.org",
		"@type": "BeautySalon",
		"name": "Braid with Petra",
		"description": "Professional braiding, hair styling, and nail services in Douala, Cameroon",
		"url": "https://www.braidwithpetra.ca",
		"telephone": "+237651844664",
		"priceRange": "$$",
		"image": "https://www.braidwithpetra.ca/images/braiding-1.jpg",
		"address": {
			"@type": "PostalAddress",
			"streetAddress": "Bonaberi",
			"addressLocality": "Douala",
			"addressRegion": "Littoral",
			"addressCountry": "CM"
		},
		"geo": {
			"@type": "GeoCoordinates",
			"latitude": "4.0511",
			"longitude": "9.7679"
		},
		"openingHoursSpecification": [
			{
				"@type": "OpeningHoursSpecification",
				"dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
				"opens": "08:00",
				"closes": "18:00"
			},
			{
				"@type": "OpeningHoursSpecification",
				"dayOfWeek": "Saturday",
				"opens": "09:00",
				"closes": "16:00"
			}
		],
		"sameAs": [
			"https://www.instagram.com/braid_with_petra"
		]
	}
	</script>
	
NEWHEAD

echo ""
echo -e "${BLUE}🔄 Updating HEAD section...${NC}"

# Extract everything before <head>
sed -n '1,/<head>/p' index.html | head -n -1 > /tmp/before-head.txt

# Extract everything from <!-- Custom Styles for New Features --> onwards
sed -n '/<!-- Custom Styles for New Features -->/,$p' index.html > /tmp/after-head.txt

# Combine: before + new head + after
cat /tmp/before-head.txt /tmp/new-head-section.txt /tmp/after-head.txt > index.html

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ HEAD section updated successfully${NC}"
else
    echo -e "${RED}❌ Failed to update HEAD section${NC}"
    echo -e "${YELLOW}⚠️  Restoring from backup...${NC}"
    cp "$BACKUP_FILE" index.html
    exit 1
fi

# Verify the file is valid
if grep -q "Purple BP Favicon" index.html && grep -q "Schema.org" index.html; then
    echo -e "${GREEN}✓ Verification passed${NC}"
else
    echo -e "${RED}❌ Verification failed${NC}"
    echo -e "${YELLOW}⚠️  Restoring from backup...${NC}"
    cp "$BACKUP_FILE" index.html
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Update Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📊 Changes made:${NC}"
echo "  • Added SEO meta tags"
echo "  • Added Open Graph tags (social sharing)"
echo "  • Added Twitter Card tags"
echo "  • Added Schema.org structured data"
echo "  • Added purple BP favicon (her favorite color!)"
echo "  • Added geo tags for local SEO"
echo ""
echo -e "${BLUE}💾 Backup saved as:${NC} $BACKUP_FILE"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "  1. Review changes: code index.html"
echo "  2. Deploy to website: ./deploy.sh"
echo "  3. Wait 3-5 minutes"
echo "  4. Check browser tab for purple BP icon! 💜"
echo ""

# Clean up temp files
rm -f /tmp/new-head-section.txt /tmp/before-head.txt /tmp/after-head.txt
