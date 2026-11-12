const express = require('express');
const app = express();
const path = require("path")


app.get("/download", (req, res) => {

    const executablePath = path.join(
        __dirname,
        "swift-code",
        "MySwiftExecutable"
    );

    res.download(executablePath, "MySwiftExecutable", (err) => {

        if (err) {
            console.error("Download failed:", err);

            if (!res.headersSent) {
                res.status(500).send("Unable to download executable");
            }
        }

    });

});
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});