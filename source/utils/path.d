module utils.path;

import std.stdio : writeln;
import std.stdio : File;
import std.exception : ErrnoException;


enum size_t KB = 1 << 10;


/// helper function to read a file's content
/// Returns: string
string readFile(immutable string path)
{
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