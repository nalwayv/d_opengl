/// Path
module utils.path;


import std.stdio : File;
import std.exception : ErrnoException;
import std.file;
import std.outbuffer;


enum size_t KB = 1 << 10;


/// helper function to read a file's content
/// Returns: string
string readFile(immutable string path)
{
    if(!exists(path))
    {
        throw new Exception("ERROR: file not found");
    }

    auto chunk = KB * 4;
    string result;

    try
    {
        auto file = File(path, "r");

        foreach(ubyte[] buffer; file.byChunk(chunk))
        {
            result ~= buffer;
        }
    }
    catch(ErrnoException e)
    {
        throw new Exception("ERROR: ", e.msg);
    }

    return result;
}


/// helper function to write content to file
void writeFile(immutable string path, string content)
{
    try
    {
        auto file = File(path, "w");
        file.write(content);
    }
    catch (ErrnoException e)
    {
        throw new Exception("ERROR: ", e.msg);
    }
}