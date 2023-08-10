<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="data">
		<Requests>
			<Request>
				<xsl:attribute name="RequestId"><xsl:value-of select="attribute[@name = 'RequestID']/@value"/></xsl:attribute>
				<xsl:attribute name="Type"><xsl:value-of select="attribute[@name = 'RequestTypeID']/@text"/></xsl:attribute>
				<xsl:attribute name="TypeId"><xsl:value-of select="attribute[@name = 'RequestTypeID']/@value"/></xsl:attribute>
				<xsl:attribute name="Pending">0</xsl:attribute>
				<Episode/>
				<RequestData>
					<xsl:copy-of select="attribute"/>
				</RequestData>
			</Request>
		</Requests>
	</xsl:template> 
</xsl:stylesheet>
