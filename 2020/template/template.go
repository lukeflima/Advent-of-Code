package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/joho/godotenv"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: template <day>")
		os.Exit(1)
	}

	godotenv.Load()

	day_str := os.Args[1]
	day, err := strconv.Atoi(day_str)
	day_folder := fmt.Sprintf("day%02d", day)
	if err != nil {
		fmt.Println("Error converting day to int:", err)
		os.Exit(1)
	}

	err = os.Mkdir(day_folder, 0755)
	if err != nil {
		fmt.Println("Error creating directory:", err)
		os.Exit(1)
	}

	err = CopyFile("template/template_folder/main.go", filepath.Join(day_folder, "main.go"))
	if err != nil {
		fmt.Println("Error copying file:", err)
		os.Exit(1)
	}

	os.Create(filepath.Join(day_folder, "sample.txt"))

	session_id := os.Getenv("SESSION_ID")
	if session_id == "" {
		fmt.Println("SESSION_ID is not set")
		os.Exit(1)
	}

	cookie := http.Cookie{
		Name:  "session",
		Value: session_id,
	}

	req, err := http.NewRequest("GET", "https://adventofcode.com/2020/day/"+day_str+"/input", nil)
	if err != nil {
		fmt.Println("Error creating request:", err)
		os.Exit(1)
	}
	req.AddCookie(&cookie)

	client := http.DefaultClient
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error sending request:", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response:", err)
		os.Exit(1)
	}

	err = os.WriteFile(filepath.Join(day_folder, "input.txt"), body, 0644)
	if err != nil {
		fmt.Println("Error writing file:", err)
		os.Exit(1)
	}
	fmt.Print(len(body), " bytes\n")
}

func CopyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, sourceFile)
	return err
}
