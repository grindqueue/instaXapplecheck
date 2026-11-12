
const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { execFile } = require("child_process");

const app = express();

const SWIFT_EXE = path.join(__dirname, "swift-code", "MySwiftExecutable");
const UPLOADS_DIR = path.join(__dirname, "uploads");

// GET /run?image=image1.jpg
app.get("/cheekyboy", (req, res) => {
  const image = path.basename(req.query.image || "");
  if (!image) return res.status(400).json({ error: "image query param required" });

  const imagePath = path.join(UPLOADS_DIR, image);

  execFile(SWIFT_EXE, [imagePath], (err, stdout, stderr) => {
    if (err) return res.status(500).json({ error: stderr || err.message });
    res.json({ image, output: stdout.trim() });
  });
});

// Create uploads directory if it doesn't exist
const uploadDir = process.env.UPLOAD_DIR ||
    path.join(__dirname, "uploads");

fs.mkdirSync(uploadDir, { recursive: true });

// Configure image storage
const storage = multer.diskStorage({

    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },

    filename: (req, file, cb) => {
        const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname)}`;
        cb(null, filename);
    }

});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024
    },
    fileFilter: (req, file, cb) => {
        if (!file.mimetype.startsWith("image/")) {
            return cb(new Error("Only image files are allowed"));
        }

        cb(null, true);
    }
});

// Receive uploaded images
app.post("/uploads", upload.single("image"), (req, res) => {

    if (!req.file) {
        return res.status(400).json({
            message: "No image received"
        });
    }

    res.status(200).json({
        message: "Image successfully received",
        filename: req.file.filename
    });

});
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});