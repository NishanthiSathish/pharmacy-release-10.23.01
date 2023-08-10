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
					<xsl:choose>
						<xsl:when test="attribute[@name='RequestTypeID']/@text='Infusion Prescription'">
							<xsl:call-template name="ProcessPrescriptionInfusion"/>
						</xsl:when>
						<xsl:when test="attribute[@name='RequestTypeIDID']/@text='ProductOrder'">
							<xsl:call-template name="ProcessProductOrder"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="attribute"/>
						</xsl:otherwise>
					</xsl:choose>
					<attribute name="PrescriptionAction" value="Create"/>
					<attribute name="ExternalPrescriptionID">
						<xsl:attribute name="value"><xsl:value-of select="attribute[@name='RequestID']/@value"/></xsl:attribute>
					</attribute>
					<attribute name="LabelIssueType" value="D" text="Discharge"/>
				</RequestData>
			</Request>
		</Requests>
	</xsl:template>
	 
	<xsl:template name="ProcessPrescriptionInfusion">
		<xsl:for-each select="attribute">
			<xsl:choose>
				<xsl:when test="@name='ProductID'">
					<attribute name="ProductID">
						<xsl:attribute name="value"><xsl:value-of select="../Ingredients/Product[@IngredientID='1']/@ProductID"/></xsl:attribute>
						<xsl:attribute name="text"><xsl:value-of select="../Ingredients/Product[@IngredientID='1']/@Description"/></xsl:attribute>
					</attribute>
					<attribute name="UnitID_Dose">
						<xsl:attribute name="value"><xsl:value-of select="../Ingredients/Product[@IngredientID='1']/@UnitID"/></xsl:attribute>
					</attribute>
					<attribute name="Dose">
						<xsl:attribute name="value"><xsl:value-of select="../Ingredients/Product[@IngredientID='1']/@Quantity"/></xsl:attribute>
						<xsl:attribute name="text"/>
					</attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/><!--- copy the current node and its descendants only -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>	
	</xsl:template>
	
	<xsl:template name="ProcessProductOrder">
		<xsl:copy-of select="attribute"/>
		<attribute name="StartDate">
			<xsl:attribute name="value"><xsl:value-of select="substring(attribute[@name='RequestDate']/@value,1,19)"/></xsl:attribute>
			<xsl:attribute name="text"/>		
		</attribute>
	</xsl:template></xsl:stylesheet>
