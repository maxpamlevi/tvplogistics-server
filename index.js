const axios = require('axios');
const ExcelJS = require('exceljs');
const fs = require('fs');

const urls = JSON.parse(process.argv[2]);
const param1 = process.argv[3]; // Get param1 from the command line arguments


async function downloadFile(url) {
    try {
        const response = await axios.get(url, { responseType: 'arraybuffer' });
        return response.data;
    } catch (error) {
        console.error(`Error downloading file from ${url}:`, error);
        throw error;
    }
}

async function mergeExcelFiles(urls) {
    const workbook = new ExcelJS.Workbook();

    for (const { url, name } of urls) {
        const fileBuffer = await downloadFile(url);

        const tempWorkbook = new ExcelJS.Workbook();
        await tempWorkbook.xlsx.load(fileBuffer);

        tempWorkbook.eachSheet((sheet, id) => {
            let sheetName = workbook.getWorksheet(sheet.name) ? `${sheet.name} - ${name}` : sheet.name;
            const newSheet = workbook.addWorksheet(`${sheetName}`);

            // Copy column widths
            // sheet.columns.forEach((col, index) => {
            //     newSheet.getColumn(index + 1).width = col.width;
            // });

            sheet.eachRow((row, rowIndex) => {
                const newRow = newSheet.getRow(rowIndex);
                row.eachCell({ includeEmpty: true }, (cell, colNumber) => {
                    const newCell = newRow.getCell(colNumber);
                    if (cell.type === ExcelJS.ValueType.Formula) {
                        newCell.value = cell.result;
                    } else {
                        newCell.value = cell.value;
                    }
                    newCell.style = cell.style;
                });
                newRow.commit();
            });

            sheet.model.merges.forEach((merge) => {
                newSheet.mergeCells(merge);
            });

            sheet.getImages().forEach(image => {
                const imageId = workbook.addImage({
                    buffer: tempWorkbook.getImage(image.imageId).buffer,
                    extension: tempWorkbook.getImage(image.imageId).extension,
                });
                newSheet.addImage(imageId, image.range);
            });
        });
    }

    const outputFilePath = `tmp/${param1}.xlsx`;
    await workbook.xlsx.writeFile(outputFilePath);
}

mergeExcelFiles(urls).catch(console.error);