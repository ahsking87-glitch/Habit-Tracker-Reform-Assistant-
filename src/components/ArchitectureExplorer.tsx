import React, { useState } from 'react';
import {
  FolderTree,
  FileCode,
  Copy,
  Check,
  Search,
  ExternalLink,
  Layers,
  Smartphone,
  Shield,
  Clock,
  Sparkles,
  Terminal,
  BookOpen
} from 'lucide-react';
import { FLUTTER_CODEBASE } from '../data/flutterCodebase';
import { CodeFile } from '../types';

interface ArchitectureExplorerProps {
  initialFilePath?: string;
}

export const ArchitectureExplorer: React.FC<ArchitectureExplorerProps> = ({
  initialFilePath,
}) => {
  const [selectedFile, setSelectedFile] = useState<CodeFile>(() => {
    if (initialFilePath) {
      const match = FLUTTER_CODEBASE.find((f) => f.path === initialFilePath);
      if (match) return match;
    }
    return FLUTTER_CODEBASE[0];
  });

  const [categoryFilter, setCategoryFilter] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [copied, setCopied] = useState<boolean>(false);

  // Filtered files
  const filteredFiles = FLUTTER_CODEBASE.filter((file) => {
    const matchesCategory =
      categoryFilter === 'all' || file.category === categoryFilter;
    const matchesSearch =
      file.path.toLowerCase().includes(searchQuery.toLowerCase()) ||
      file.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      file.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      file.tags.some((t) => t.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchesCategory && matchesSearch;
  });

  const handleCopyCode = () => {
    navigator.clipboard.writeText(selectedFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 h-[760px] bg-[#051410] rounded-3xl border border-emerald-900/60 p-4 overflow-hidden shadow-2xl">
      {/* Sidebar: File Tree & Category Tabs (4 cols) */}
      <div className="lg:col-span-4 flex flex-col h-full border-r border-emerald-900/40 pr-3 space-y-3">
        {/* Search Input */}
        <div className="relative">
          <Search className="w-4 h-4 text-emerald-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search code, services, Android/iOS..."
            className="w-full bg-[#08201a] border border-emerald-800/60 rounded-xl pl-9 pr-3 py-2 text-xs text-white placeholder-emerald-400/50 focus:outline-none focus:border-amber-400"
          />
        </div>

        {/* Category Pills */}
        <div className="flex flex-wrap gap-1.5">
          {[
            { id: 'all', label: 'All Files' },
            { id: 'flutter_core', label: 'Flutter Core' },
            { id: 'android_native', label: 'Android Native' },
            { id: 'ios_native', label: 'iOS Native' },
            { id: 'architecture_docs', label: 'Policy & Docs' },
          ].map((cat) => (
            <button
              key={cat.id}
              onClick={() => setCategoryFilter(cat.id)}
              className={`px-2.5 py-1 rounded-lg text-[11px] font-medium transition-colors ${
                categoryFilter === cat.id
                  ? 'bg-amber-500/20 text-amber-300 border border-amber-400/50'
                  : 'bg-emerald-950/40 text-emerald-300/70 hover:text-white border border-emerald-900/50'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* File Tree List */}
        <div className="flex-1 overflow-y-auto space-y-1.5 pr-1">
          {filteredFiles.map((file) => {
            const isSelected = selectedFile.path === file.path;
            return (
              <div
                key={file.path}
                onClick={() => setSelectedFile(file)}
                className={`p-2.5 rounded-xl border transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-emerald-900/40 border-amber-400/60 shadow-sm'
                    : 'bg-[#071d17]/50 border-emerald-950 hover:border-emerald-800/60 hover:bg-[#09241d]/50'
                }`}
              >
                <div className="flex items-center gap-2">
                  <FileCode
                    className={`w-4 h-4 shrink-0 ${
                      isSelected ? 'text-amber-400' : 'text-emerald-400/70'
                    }`}
                  />
                  <div className="min-w-0 flex-1">
                    <p
                      className={`text-xs font-mono font-medium truncate ${
                        isSelected ? 'text-white' : 'text-emerald-200/80'
                      }`}
                    >
                      {file.name}
                    </p>
                    <p className="text-[10px] text-emerald-400/50 truncate font-mono mt-0.5">
                      {file.path}
                    </p>
                  </div>
                  <span
                    className={`text-[9px] uppercase px-1.5 py-0.5 rounded font-mono font-bold ${
                      file.language === 'dart'
                        ? 'bg-blue-950/80 text-blue-300 border border-blue-800/40'
                        : file.language === 'kotlin'
                        ? 'bg-purple-950/80 text-purple-300 border border-purple-800/40'
                        : file.language === 'swift'
                        ? 'bg-orange-950/80 text-orange-300 border border-orange-800/40'
                        : 'bg-emerald-950 text-emerald-300 border border-emerald-800/40'
                    }`}
                  >
                    {file.language}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Main Code View Area (8 cols) */}
      <div className="lg:col-span-8 flex flex-col h-full bg-[#030d0a] rounded-2xl border border-emerald-900/60 overflow-hidden">
        {/* Code Header Bar */}
        <div className="px-4 py-2.5 bg-[#061814] border-b border-emerald-900/60 flex items-center justify-between">
          <div className="flex items-center gap-2 min-w-0">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
            <span className="font-mono text-xs font-semibold text-white truncate">
              {selectedFile.path}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleCopyCode}
              className="py-1 px-2.5 rounded-lg bg-emerald-900/50 hover:bg-emerald-800/60 border border-emerald-700/50 text-xs font-medium text-emerald-200 flex items-center gap-1.5 transition-colors"
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5 text-amber-300" />
                  <span className="text-amber-300">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Code</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* File Description & Tags */}
        <div className="px-4 py-2 bg-[#051713] border-b border-emerald-900/40 flex items-center justify-between text-xs">
          <p className="text-emerald-200/80 line-clamp-1">{selectedFile.description}</p>
          <div className="flex items-center gap-1 shrink-0 ml-2">
            {selectedFile.tags.map((tag) => (
              <span
                key={tag}
                className="px-2 py-0.5 rounded-md bg-emerald-950 border border-emerald-800/60 text-[10px] text-amber-300/90 font-mono"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>

        {/* Code Viewer with Line Numbers */}
        <div className="flex-1 overflow-y-auto p-4 font-mono text-xs leading-relaxed text-emerald-100 bg-[#020b08]">
          <pre className="overflow-x-auto whitespace-pre font-code">
            <code>
              {selectedFile.content.split('\n').map((line, idx) => (
                <div key={idx} className="flex hover:bg-emerald-950/40 px-1 rounded">
                  <span className="w-10 text-right pr-4 text-emerald-700/60 select-none">
                    {idx + 1}
                  </span>
                  <span
                    className={
                      line.startsWith('//') || line.startsWith('/*') || line.startsWith('*') || line.startsWith('#')
                        ? 'text-emerald-500/80 italic'
                        : line.includes('class ') || line.includes('interface ') || line.includes('service')
                        ? 'text-amber-300 font-semibold'
                        : line.includes('import ') || line.includes('package ')
                        ? 'text-cyan-400/90'
                        : 'text-emerald-100'
                    }
                  >
                    {line}
                  </span>
                </div>
              ))}
            </code>
          </pre>
        </div>
      </div>
    </div>
  );
};
