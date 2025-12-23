/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ims.controller;

/**
 *
 * @author ars3lan
 */

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.ims.dao.InvoiceDAO;
import com.ims.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReceiptServlet", urlPatterns = {"/ReceiptServlet"})
public class ReceiptServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int invoiceId = Integer.parseInt(request.getParameter("id"));
            double total = Double.parseDouble(request.getParameter("total")); // Pass total for ease
            String date = request.getParameter("date");
            
            InvoiceDAO dao = new InvoiceDAO();
            List<Product> items = dao.getInvoiceProducts(invoiceId);

            // 1. Set PDF Response
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline; filename=Receipt_" + invoiceId + ".pdf");

            // 2. Create Document
            Document doc = new Document();
            PdfWriter.getInstance(doc, response.getOutputStream());
            doc.open();

            // 3. Header
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
            Paragraph title = new Paragraph("NEXUS INVENTORY SYSTEM", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            doc.add(title);
            
            doc.add(new Paragraph("\n")); // Spacer
            
            // 4. Info Section
            Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
            doc.add(new Paragraph("Receipt ID: #" + invoiceId, normalFont));
            doc.add(new Paragraph("Date: " + date, normalFont));
            doc.add(new Paragraph("\n"));

            // 5. Items Table
            PdfPTable table = new PdfPTable(4); // 4 Columns
            table.setWidthPercentage(100);
            table.setWidths(new float[]{3, 1, 1, 1}); // Column widths

            // Headers
            addHeader(table, "Item");
            addHeader(table, "Qty");
            addHeader(table, "Price");
            addHeader(table, "Subtotal");

            // Rows
            for (Product p : items) {
                table.addCell(p.getName());
                table.addCell(String.valueOf(p.getQuantity()));
                table.addCell("$" + p.getPrice());
                table.addCell("$" + (p.getQuantity() * p.getPrice()));
            }

            doc.add(table);

            // 6. Total Footer
            Paragraph totalPara = new Paragraph("\nTotal Amount: $" + total, new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD));
            totalPara.setAlignment(Element.ALIGN_RIGHT);
            doc.add(totalPara);
            
            // 7. Footer Message
            Paragraph footer = new Paragraph("\nThank you for your business!", new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC));
            footer.setAlignment(Element.ALIGN_CENTER);
            doc.add(footer);

            doc.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addHeader(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD)));
        cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        cell.setPadding(5);
        table.addCell(cell);
    }
}
